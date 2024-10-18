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
  console.log('Calling getLikes method');

  const { userId } = event.queryStringParameters || event;

  // 1) Return error if any required props are missing
  if (!userId) {
    throw new Error('Some required params missing!');
  }

  //  query
  const query = `
    SELECT * FROM likes
    WHERE user_id = $1
    ;
  `;

  const values = [userId];
  try {
    const result = await pool.query(query, values);
    console.log('result: ', result);
    // want to return an object
    const data = result.rows;

    const response = {
      success: true,
      status: 200,
      message: 'successful query',
      data,
    };
    return response;
  } catch (err) {
    console.error('Error in getLikes lambda', err.message);
    const response = {
      success: false,
      status: 500,
      message: err.message,
      data: [],
    };
    return response;
  }
};
