from datetime import datetime
import json
import httpx
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--server", default="localhost")
parser.add_argument("-u", "--user", default="root")
parser.add_argument("-p", "--password", default="Admin123.")
parser.add_argument("-d", "--database", default="demodb")
parser.add_argument("-c", "--count", default=2)

args = parser.parse_args()

URL = f"https://randomuser.me/api/?results={args.count}&format=json&dl&noinfo"

def get_users_from_url():
    res = httpx.get(URL)
    res.raise_for_status()
    users = res.json()
    return users["results"] if "results" in users else []


def get_users_from_file():
    with open("users.json", "r") as f:
        users = json.load(f)
    return users


users = get_users_from_url()

import mysql.connector

mydb = mysql.connector.connect(
    host=args.server, user=args.user, password=args.password, database=args.database
)

mycursor = mydb.cursor()
sql = "INSERT INTO users (title, first, last, street, city, state, postcode, country, gender, " \
"email, uuid, username, password, phone, cell, dob, registered, large, medium, thumbnail, nat) " \
"VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"

vals = []
for user in users:
    # pprint(user)
    vals.append(
        (
            user["name"]["title"],
            user["name"]["first"],
            user["name"]["last"],
            str(user["location"]["street"]["number"])
            + " "
            + user["location"]["street"]["name"],
            user["location"]["city"],
            user["location"]["state"],
            user["location"]["postcode"],
            user["location"]["country"],
            user["gender"],
            user["email"],
            user["login"]["uuid"],
            user["login"]["username"],
            user["login"]["password"],
            user["phone"],
            user["cell"],
            datetime.fromisoformat(user["dob"]["date"]).strftime('%Y-%m-%d %H:%M:%S'),
            datetime.fromisoformat(user["registered"]["date"]).strftime('%Y-%m-%d %H:%M:%S'),
            user["picture"]["large"],
            user["picture"]["medium"],
            user["picture"]["thumbnail"],
            user["nat"],
        )
    )

# print(vals)

mycursor.executemany(sql, vals)
mydb.commit()

print(mycursor.rowcount, "row(s) inserted.")


_ = {
    "gender": "female",
    "name": {"title": "Mrs", "first": "Anneke", "last": "Diefenbach"},
    "location": {
        "street": {"number": 6741, "name": "Am Sportplatz"},
        "city": "Braubach",
        "state": "Sachsen",
        "country": "Germany",
        "postcode": 99196,
        "coordinates": {"latitude": "-71.3430", "longitude": "-10.0319"},
        "timezone": {"offset": "+4:30", "description": "Kabul"},
    },
    "email": "anneke.diefenbach@example.com",
    "login": {
        "uuid": "644bcd3c-6aee-4f8e-9575-d4e21ea4801d",
        "username": "lazyfrog655",
        "password": "boiler",
        "salt": "hodaNSMn",
        "md5": "a05dd87b5c89fee7de81524d6e0edd52",
        "sha1": "441bc06e0e3b615580bd20e4273a1cec4701eb0e",
        "sha256": "e3302fa0267fcb4467360fc5ad04968bb646226c586157d18cc15d5ea4da208c",
    },
    "dob": {"date": "1971-04-02T04:15:10.564Z", "age": 54},
    "registered": {"date": "2016-01-30T06:52:59.011Z", "age": 9},
    "phone": "0971-2258406",
    "cell": "0179-3185491",
    "id": {"name": "SVNR", "value": "76 010471 D 926"},
    "picture": {
        "large": "https://randomuser.me/api/portraits/women/62.jpg",
        "medium": "https://randomuser.me/api/portraits/med/women/62.jpg",
        "thumbnail": "https://randomuser.me/api/portraits/thumb/women/62.jpg",
    },
    "nat": "DE",
}



_ = {
    "type":"insert",
    "timestamp":1750725549000,
    "binlog_filename":"delta.000003",
    "binlog_position":40565,
    "database":"demodb",
    "table_name":"users",
    "table_id":121,
    "columns":[
        {"id":1,"name":"id","column_type":4,"value":123},
        {"id":2,"name":"title","column_type":-1,"value":"Miss"},
        {"id":3,"name":"first","column_type":-1,"value":"Carolyn"},
        {"id":4,"name":"last","column_type":-1,"value":"Sims"},
        {"id":5,"name":"street","column_type":-1,"value":"5224 Manor Road"},
        {"id":6,"name":"city","column_type":-1,"value":"Oranmore"},
        {"id":7,"name":"state","column_type":-1,"value":"Limerick"},
        {"id":8,"name":"postcode","column_type":-1,"value":"64333"},
        {"id":9,"name":"country","column_type":-1,"value":"Ireland"},
        {"id":10,"name":"gender","column_type":-1,"value":"female"},
        {"id":11,"name":"email","column_type":-1,"value":"carolyn.sims@example.com"},
        {"id":12,"name":"uuid","column_type":-1,"value":"fb614311-e147-497d-924f-6967e97eae2d"},
        {"id":13,"name":"username","column_type":-1,"value":"yellowgoose454"},
        {"id":14,"name":"password","column_type":-1,"value":"stress"},
        {"id":15,"name":"phone","column_type":-1,"value":"071-974-8590"},
        {"id":16,"name":"cell","column_type":-1,"value":"081-985-7723"},
        {"id":17,"name":"dob","column_type":93,"value":"Mon Apr 23 09:01:15 BST 1984"},
        {"id":18,"name":"registered","column_type":93,"value":"Tue Nov 02 14:56:34 GMT 2021"},
        {"id":19,"name":"large","column_type":-1,"value":"https://randomuser.me/api/portraits/women/3.jpg"},
        {"id":20,"name":"medium","column_type":-1,"value":"https://randomuser.me/api/portraits/med/women/3.jpg"},
        {"id":21,"name":"thumbnail","column_type":-1,"value":"https://randomuser.me/api/portraits/thumb/women/3.jpg"},
        {"id":22,"name":"nat","column_type":-1,"value":"IE"}
    ]
}
