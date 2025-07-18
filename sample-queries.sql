INSERT INTO users (
    id, title, first, last, street, city, state, postcode, country, gender, email, uuid,
    username, password, phone, cell, dob, registered, large, medium, thumbnail, nat) 
VALUES (
    6, 'Miss', 'Nicole', 'Høyland', '8454 Fagertunveien', 'Sem', 'Telemark', '1670', 'Norway', 'female', 'nicole.hoyland@example.com', 'fb8e27d0-2bfb-4636-93bc-34b2628fbdc1', 
    'silverbutterfly165', 'stress', '50211868', '45293426', 'Wed Dec 06 17:47:14 GMT 1989', 'Fri May 20 17:48:50 BST 2016', 'https://randomuser.me/api/portraits/women/10.jpg', 'https://randomuser.me/api/portraits/med/women/10.jpg', 'https://randomuser.me/api/portraits/thumb/women/10.jpg', 'NO');


INSERT INTO users (title, first, last, street, city, state, postcode, country, gender, email, uuid,
    username, password, phone, cell, dob, registered, large, medium, thumbnail, nat) 
VALUES (
    'Mr', 'Neil', 'Reed', '662 Depaul Dr', 'Cairns', 'New South Wales', '8758', 'Australia', 'male', 'neil.reed@example.com', '39824c35-a992-4bdc-9dde-3c974984e03b', 
    'beautifulfish433', 'fishy', '07-5932-9765', '0425-290-337', 'Tue Jul 16 02:55:30 BST 1946', 'Sat Dec 06 05:39:21 GMT 2008', 'https://randomuser.me/api/portraits/men/36.jpg', 'https://randomuser.me/api/portraits/med/men/36.jpg', 'https://randomuser.me/api/portraits/thumb/men/36.jpg', 'AU')



Schema(
    fieldSchemas:[
        FieldSchema(name:users.id, type:int, comment:null), 
        FieldSchema(name:users.title, type:string, comment:null), 
        FieldSchema(name:users.first, type:string, comment:null), 
        FieldSchema(name:users.last, type:string, comment:null), 
        FieldSchema(name:users.street, type:string, comment:null), 
        FieldSchema(name:users.city, type:string, comment:null), 
        FieldSchema(name:users.state, type:string, comment:null), 
        FieldSchema(name:users.postcode, type:string, comment:null), 
        FieldSchema(name:users.country, type:string, comment:null), 
        FieldSchema(name:users.gender, type:string, comment:null), 
        FieldSchema(name:users.email, type:string, comment:null), 
        FieldSchema(name:users.uuid, type:string, comment:null), 
        FieldSchema(name:users.username, type:string, comment:null), 
        FieldSchema(name:users.password, type:string, comment:null), 
        FieldSchema(name:users.phone, type:string, comment:null), 
        FieldSchema(name:users.cell, type:string, comment:null), 
        FieldSchema(name:users.dob, type:string, comment:null), 
        FieldSchema(name:users.registered, type:string, comment:null), 
        FieldSchema(name:users.large, type:string, comment:null), 
        FieldSchema(name:users.medium, type:string, comment:null), 
        FieldSchema(name:users.thumbnail, type:string, comment:null), 
        FieldSchema(name:users.nat, type:string, comment:null)
    ], 
    properties:null
)

CREATE EXTERNAL TABLE t1 (
    id INT,
    name STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS PARQUET
LOCATION 'maprfs:///user/mapr/t1';
