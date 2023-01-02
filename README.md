# README

Run with mysql
```
docker run --rm -p 3306:3306 -e MYSQL_ROOT_HOST=% -e MYSQL_ROOT_PASSWORD=123456 mysql/mysql-server
export DATABASE_URL=mysql2://root:123456@127.0.0.1:3306/todo_app

bundle install

bundle exec rake db:setup
rails s
```


Run with postgresql
```shell
docker run --rm -p 5432:5432 -e POSTGRES_PASSWORD=123456 postgres
export DATABASE_URL=postgresql://postgres:123456@127.0.0.1:5432/todo_app

bundle install
bundle exec rake db:setup
rails s
```
