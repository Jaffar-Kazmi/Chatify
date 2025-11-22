import { Pool } from 'pg';

const pool = new Pool({
    user: 'jaffar',
    password: 'admin',
    host: 'localhost',
    port: 5432,
    database: 'chatify_db'
})

export default pool;

