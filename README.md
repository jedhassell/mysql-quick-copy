# mysql-quick-copy - A faster database copy solution
This method copies binary data files in the MySQL data directory rather than using the `mysqldump` tool provided. 

### Usage
* #### Export the table data to the `/tmp` folder. 
```bash
./export.rb -d 'my_database' -u 'user' -p 'password' -o '/tmp'
./export.rb -h # for detailed information
```

* #### Copy contents of `/tmp/my_database` to the destination computer.

* #### Import the table data 
```bash
./import.rb -d 'my_database' -u 'user' -p 'password' -s '/tmp'
```
### Notes
* Script needs to be run on the server.
* This method locks each table individually during the export process.
* Script needs access to the MySQL `datadir` directory.
