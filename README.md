## Running
To run, install Meteor and then just use the `meteor` command.

## Development
Use `npm install` to get the development dependencies, including the CoffeeScript linter.

## Tests
To run the acceptance tests, run `npm install` and then `npm run chimp`. Tests are currently written in JavaScript, not CoffeeScript, due to the limitations of Chimp.

## Deployment
  - `meteor build /tmp/ehabuild --directory`
  - `cp ./Dockerfile /tmp/ehabuild/bundle/`
  - `docker build -t eha/nia-monitor /tmp/ehabuild/bundle/`
  - `docker run --name mongo -d mongo`
  - `docker run -d -p 8080:8080 --link mongo -e PORT=8080 -e MAIL_URL=smtp://smtp.eha.com/ -e MONGO_URL=mongodb://mongo/nia -e ROOT_URL=http://192.168.99.100 eha/nia-monitor`

## Accessing the EHA SPARQL Database
If you have ssh access to the niam.eha.io machine, you can set up an ssh tunnel to test NIAM using its database like so:

Create the tunnel in a separate terminal:
```
ssh -L 8890:localhost:8890 ubuntu@niam.eha.io
```

Start meteor with the following environment variable:
```
SPARQURL=localhost:8890/sparql?graph=http://eha.io/t11 meteor
```
