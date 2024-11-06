from faker import Faker

fake = Faker()

# add inserts for 25 possible cities
for i in range(1, 26):
    city = fake.city()
    print(f"INSERT INTO city (id, name) VALUES ({i}, '{city}');")

# add inserts for 10000 possible people from the 10 cities
for i in range(1, 10001):
    name = fake.name()
    city = fake.random_int(1, 25)
    print(f"INSERT INTO person (id, name, city_id) VALUES ({i}, '{name}', '{city}');")

