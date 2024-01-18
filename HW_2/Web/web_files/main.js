import express from 'express';
import mariadb from 'mariadb';

const port = 8000; // задаем порт
const app = express(); // создаем web сервер

const pool = mariadb.createPool({
    host: process.env.DB_SERVER_NAME,
    user: process.env.DB_USER,
    port: process.env.DB_PORT,
    password: process.env.MARIADB_ROOT_PASSWORD,
    connectionLimit: 5
});

app.get('/*', (req, res) => {

    if (req.path === '/') {
        // res.send('Hello World!');
        asyncFunction().then( (val) => {
            res.send(val);
        });

        res.status(200);
        return;
    }

    if (req.path === '/health') {
        res.status(200).send({"status": "OK"});
        return;
    }

    res.status(404).end();
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
})

async function asyncFunction(res) {
    let conn;
    try {
        conn = await pool.getConnection();

        let result = await conn.query(`use ${process.env.DATABASE_NAME};`);

        // console.log('res: ' + res);

        result = await conn.query(`select * from ${process.env.TABLE_NAME};`);
        // console.log(res);

        let resObj = {};

        result.forEach( (v , i) => resObj[v.name] = v.age);

        return resObj;

    } catch (err) {
        console.log('ERROR: ' + err);
    } finally {
        if (conn) conn.end();
    }
}
