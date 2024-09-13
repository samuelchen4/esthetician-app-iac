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
  try {
    console.log('getUserByClerkId method start!');
    console.log('Received event:', JSON.stringify(event, null, 2));
    console.log('DB successfully connected!');

    const { clerkUserId } = event.pathParameters;

    if (!clerkUserId) {
      console.error('Missing clerkUserId');
      throw new Error('Missing clerkUserId');
    }

    // build query
    // join profile
    const queryText = `
    SELECT
        *
    FROM
        users
    WHERE clerk_user_id = $1
    ;
      `;

    const values = [clerkUserId];

    const result = await pool.query(queryText, values);

    const data = result.rows.length === 0 ? null : result.rows;

    const response = {
      success: true,
      status: 200,
      message: 'No values returned!',
      data: data,
    };
    return response;
  } catch (err) {
    const response = {
      success: false,
      status: 500,
      message: err.message,
      data: err,
    };
    console.error('Error executing query', response);
    return response;
  }
};
