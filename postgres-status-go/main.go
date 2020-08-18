package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"

	_ "github.com/lib/pq"
)

const stateQuery = `
	SELECT
		CASE WHEN pg_is_in_recovery() THEN true ELSE false END as replica,
		CASE WHEN current_setting('transaction_read_only') = 'on' THEN true ELSE false END as readonly;
`

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if len(value) == 0 {
		return defaultValue
	}
	return value
}

func main() {
	// We disable ssl mode as it's usually not used locally and for unix sockets
	os.Setenv("PGSSLMODE", "disable")
	var PORT = getEnv("PORT", "2345")
	var DATABASE = getEnv("DATABASE_URL", "")
	db, err := sql.Open("postgres", DATABASE)
	if err != nil {
		log.Fatal("Failed to connect to postgres: ", err)
	}
	defer db.Close()

	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		var replica bool
		var readonly bool
		var status int
		err = db.QueryRow(stateQuery).Scan(&replica, &readonly)
		if err != nil {
			status = 503
			w.WriteHeader(status)
			fmt.Fprintf(w, `{"statusCode":503,"error":"%s"}`, strings.ReplaceAll(err.Error(), `"`, `\"`))
			return
		}

		var attr string
		q, _ := url.ParseQuery(req.URL.RawQuery)
		if len(q["target_session_attrs"]) == 0 {
			attr = "read-write"
		} else {
			attr = q["target_session_attrs"][0]
		}

		if (attr == "any") || (attr == "read-only" && readonly) || (attr == "read-write" && !replica) {
			status = 200
		} else {
			status = 400
		}

		w.WriteHeader(status)
		fmt.Fprintf(w, `{"statusCode":%d,"primary":%t,"replica":%t,"readonly":%t}`, status, !replica, replica, readonly)
	})

	log.Println("Listening on http://localhost:" + PORT)
	http.ListenAndServe(":"+PORT, nil)
}
