const { Pool } = require('pg');

// connect to client
const pool = new Pool({
  user: process.env.DB_USER, // Database username
  host: process.env.DB_HOST, // Database server address
  database: process.env.DB_DATABASE, // Database name
  password: process.env.DB_PASSWORD, // Database password
  port: process.env.DB_PORT, // Database port (usually 5432 for PostgreSQL)
  ssl: {
    rejectUnauthorized: false,
  },
  max: 10, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // How long a client is allowed to remain idle before being closed
  connectionTimeoutMillis: 5000, // How long to wait for a new client before throwing an error
});
console.log('Initalizing new DB connection');

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  console.log('DB successfully connected!');

  const {
    title = 'Esthetician',
    page = 1,
    limit = 10,
  } = event.queryStringParameters || event;
  const offset = (page - 1) * limit;

  //  query
  const queryText = `
        SELECT 
          u.*,
          b.business_id,
          b.title,
          b.location,
          b.cost
        FROM
          users AS u
        LEFT JOIN
          business AS b
        ON
          u.user_id = b.user_id
        WHERE
          role = $1 AND b.title = $2
        LIMIT $3
        OFFSET $4;
      `;

  const values = ['client', title, limit, offset];
  try {
    const result = await pool.query(queryText, values);

    const response = {
      success: true,
      status: 200,
      message: 'successful query',
      data: result.rows,
    };
    return response;
  } catch (err) {
    const response = {
      success: false,
      status: 500,
      message: err.message,
      data: [],
    };
    console.error('Error executing query', response);
    return response;
  }
};
