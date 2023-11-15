import express from 'express';
import mariadb from 'mariadb';

const port = 8000; // задаем порт
const app = express(); // создаем web сервер

app.get('/', (req, res) => {
  res.send('Hello World!');
  asyncFunction();
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
})

const pool = mariadb.createPool({
    host: '172.19.0.2', 
    user:'root', 
    password: 'ps123',
    connectionLimit: 5
});

function asyncFunction() {
 console.log('err')
 let conn;
 try {
   conn = pool.getConnection();
//    const rows = await conn.query("SELECT 1 as val");
//    console.log(rows); //[ {val: 1}, meta: ... ]
   conn.query("use guide;");
   const res = conn.query("select * from main_table;");
   console.log(res); // { affectedRows: 1, insertId: 1, warningStatus: 0 }

 } catch (err) {
    console.log('err: ' + err)
    throw err;
 } finally {
    console.log('final')
    if (conn) return conn.end();
 }
}