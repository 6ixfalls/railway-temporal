# Temporal on Railway
This template deploys an instance of [Temporal Server]([https://www.rabbitmq.com/](https://github.com/temporalio/temporal)) on Railway.app. The template uses a primary Temporal server, as well as a PostgreSQL database for data and a NodeJS hello-world workflow demo in the /hello-world path.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/AhDDtZ?referralCode=IQhE0B)
## Features
- Temporal (one click deploy)
- Hello World Workflow Demo (/hello-world) [(source)](https://github.com/temporalio/samples-typescript/tree/main/hello-world)
- Activities HTTP Request Example (/activities) [(source)](https://github.com/temporalio/samples-typescript/tree/main/activities-examples)
## Usage
- Click the deploy to Railway button above!
- Configure the temporal sql.yaml file in the temporal directory.
- Fill out the required environment variables, setup auth as needed.
- Deploy, and check out your new Temporal server!
## Links
Temporal - https://github.com/temporalio/temporal

TypeScript Samples - https://github.com/temporalio/samples-typescript

Temporal Documentation - https://docs.temporal.io/
