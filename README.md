# artcat-scripts

Scripts used for administering https://www.artcat.com and its associated applications

## Setup

```
bundle install
cp .env.example .env # then set to your values
```

## Scripts

# Create SSL Certificates using Amazon Certificate Manager

Given a file in your home directory `~/data/active-domains.txt`, and proper values in `.env`

```
dotenv create-ssl-certs.rb
```

This will request certificates from Amazon Web Services, then use the [dnsimple api](https://developer.dnsimple.com/v2/)
to create the needed CNAME records for DNS validation of the domain.
