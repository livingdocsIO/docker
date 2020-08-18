#[macro_use]
extern crate serde_derive;
extern crate reqwest;
extern crate clap;

use clap::Clap;
use std::fs::File;
use std::io::{Write};

#[derive(Clap)]
#[clap(name = "fetch-certificate", version = "1.0", author = "Marc Bachmann <marc@livingdocs.io>", about = "A small tool to fetch a certificate from a certificate server.")]
struct Opts {
  #[clap(default_value = "<domain>", env = "FETCH_CERTIFICATE_FILE", required = true, help = "Customize the key and cert file output path.")]
  file: String,

  #[clap(long, default_value = "<file>.cert", env = "FETCH_CERTIFICATE_CERT_FILE", help = "Customize the cert file output path.")]
  cert_file: String,

  #[clap(long, default_value = "<file>.key", env = "FETCH_CERTIFICATE_KEY_FILE", help = "Customize the key file output path.")]
  key_file: String,

  #[clap(long = "url", env = "FETCH_CERTIFICATE_URL", help = "A server to fetch certificates from")]
  url: String,

  #[clap(env = "FETCH_CERTIFICATE_TOKEN", long, help = "The bearer token to use for the server request.")]
  token: String
}

#[derive(Debug, Deserialize)]
struct Certificate {
  domain: String,
  cert: String,
  key: String
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
  let mut opts: Opts = Opts::parse();

  let client = reqwest::blocking::Client::new();
  let resp = client.get(&format!("{}/list", &opts.url))
      .bearer_auth(&opts.token)
      .send()?;

  if resp.status().is_success() {
    let parsed: Vec<Certificate> = resp.json()?;
    let cert = parsed.first().unwrap();

    opts.file = opts.file.replace("<domain>", &cert.domain);
    opts.cert_file = opts.cert_file.replace("<file>", &opts.file);
    opts.key_file = opts.key_file.replace("<file>", &opts.file);

    let mut cert_file = File::create(&opts.cert_file)?;
    let mut key_file = File::create(&opts.key_file)?;
    write!(cert_file, "{}", cert.cert)?;
    write!(key_file, "{}", cert.key)?;

    println!("Wrote {}", opts.cert_file);
    println!("Wrote {}", opts.key_file);
  } else if resp.status().is_client_error() {
    println!("Server Authentication failed with status {:?}", resp.status());
  } else {
    println!("Server Error with status {:?}", resp.status());
  }

  Ok(())
}
