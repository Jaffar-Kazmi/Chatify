import { Pool } from 'pg';

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is not set');
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
     rejectUnauthorized: false,
  },
});

pool
  .connect()
  .then((client) => {
    return client
      .query('SELECT 1')
      .then(() => {
        console.log('Connected to PostgreSQL');
        client.release();
      })
      .catch((err) => {
        client.release();
        console.error('PostgreSQL test query failed:', err);
      });
  })
  .catch((err) => {
    console.error('Could not connect to PostgreSQL:', err);
  });

export default pool;
