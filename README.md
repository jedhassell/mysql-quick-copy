# mysql-quick-copy - A faster database copy solution
This method copies binary data files in the MySQL data directory rather than using the `mysqldump` tool provided.
### Timing
For a 55GB database: 
* export ~2 minutes
* import ~3 minutes

### Usage
* #### Export the table data to the `/tmp` folder. 
```bash
./export.rb -d 'my_database' -u 'user' -p 'password' -o '/tmp'
./export.rb -h # for detailed information and defaults
```

* #### Copy `/tmp/my_database` to the destination computer. Compressing the directory can help transfer times.

* #### Import the table data 
```bash
./import.rb -d 'my_database' -u 'user' -p 'password' -s '/tmp'
./import.rb -h # for detailed information and defaults
```
### Notes
* Script needs to be run on the server with MySQL client installed.
* This method locks each table individually during the export process.
* Script needs access to the MySQL `datadir` directory.
* Only works with MySQL

### Use cases
* Copying databases for developers
* Creating test databases that are expendable
* Dumping staging data
* Do not use in production as it locks each table ~ 1-10 seconds depending on size

### TODO - open a PR :) 
* Create gem
* Create Homebrew recipe
* Slackbot integration
