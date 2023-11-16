import express from 'express';
import mariadb from 'mariadb';

const port = 8000; // задаем порт
const app = express(); // создаем web сервер

const pool = mariadb.createPool({
    host: '127.0.0.1',
    user:'root',
    port: '2221',
    password: 'ps123',
    connectionLimit: 5
});

app.get('/*', (req, res) => {
  // res.send('Hello World!');
//   asyncFunction()
//     .then();
    if (req.path === '/') {
        // res.send('Hello World!');
        let pr = asyncFunction()
        console.log('H ' + pr);
        pr.then(console.log(123));
        // .then( (result) => {
        //     console.log(result)
        //     let resObj = {};
        //     rt.forEach( (v , i) => resObj[v.name] = v.age);
        //     res.send(resObj);
        // });
        return;
    }

    if (req.path === '/health') {
        res.send('I am live');
        return;
    }

    // res.send('Bye');
    res.status(404).end();


    // console.log(res);
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
})

async function asyncFunction() {
    let conn;
    try {
        conn = await pool.getConnection();

        let res = await conn.query('use guide;');

        // console.log('res: ' + res);

        res = await conn.query("select * from main_table;");
        console.log(res);

        return res;

    } catch (err) {
        console.log(err);
    } finally {
        console.log('final')
        if (conn) return conn.end();
    }
}
