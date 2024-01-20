# Debezium exclude fields from CDC

A working example of using Debezium for CDC while excluding some columns to prevent consumption of personally private information (PII)

This project uses Docker Compose to create a mariadb instance, populate it with some sample data and then a connector config to CDC from a table in to Kafka, with some fields to be excluded.

The sample data I used is a users table with some generated data:

```
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    surname VARCHAR(50),
    email VARCHAR(100),
    date_of_birth DATE,
    signed_up DATETIME,
    user_type ENUM('user', 'admin')
);

INSERT INTO users (first_name, surname, email, date_of_birth, signed_up, user_type) VALUES
('John', 'Doe', 'john.doe@example.com', '1990-01-01', '2022-01-15 08:30:00', 'user'),
('Jane', 'Smith', 'jane.smith@example.com', '1985-05-20', '2022-02-10 09:45:00', 'admin'),
('Alice', 'Johnson', 'alice.johnson@example.com', '1992-07-11', '2022-03-05 10:00:00', 'user'),
('Bob', 'Brown', 'bob.brown@example.com', '1988-09-30', '2022-04-20 11:20:00', 'user'),
('Charlie', 'Davis', 'charlie.davis@example.com', '1995-11-15', '2022-05-25 13:45:00', 'admin');
```

I then created a connector for Debezium that included the following values to exclude the surname, email and date of birth fields from being copied to kafka.

```
"column.exclude.list": "mydatabase.users.surname, mydatabase.users.email, mydatabase.users.date_of_birth",
```

Once the connector is updated with any changes you want to make you can start the containers.

Run `docker-compose up -d` and connect to the Debezium container:

```
docker exec -it debezium /bin/bash
```

Docker compose will upload the connector in to the Debezium container, you can start the connector using to following commands:

```
curl -X PUT http://localhost:8083/connectors/myconnector/config -H "Content-Type: application/json" -d @connector_mariadb.json
```

Once I started the connector, I was able to query the messages in the resulting topic to see if the fields were present.

```
➜  ~ ./kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic testing.mydatabase.users --from-beginning | jq
```

One of the records now looks like the following example. Not much left after the sensitivie fields have been removed, but its working well.

```
  "payload": {
    "id": 5,
    "first_name": "Charlie",
    "signed_up": 1653486300000,
    "user_type": "admin"
  }
```

To test the CDC part, I added and updated a record or two in the source database, to see what the data might look like:

```

INSERT INTO users (first_name, surname, email, date_of_birth, signed_up, user_type) VALUES
('Bobby', 'Tables', 'bobby.tables@example.com', '1995-07-01', '2023-03-15 08:30:00', 'user');

update users set email = 'bobby.tables.new@example.com' where first_name = 'Bobby' and surname = 'Tables';
```

The topic content was still good, no sign of the sensitive fields being carried over:

```
  "payload": {
    "id": 6,
    "first_name": "Bobby",
    "signed_up": 1678869000000,
    "user_type": "user"
  }
```

So it works well. A 1-line change in a source connector can remove any unwanted or sensitive fields, so theres no excuse for sensitive data getting in to your Datalake!
