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
    console.log('patchNameById method start!');
    console.log('Received event:', JSON.stringify(event, null, 2));
    console.log('DB successfully connected!');

    const { userId } = event.pathParameters;
    const { firstName, lastName } = JSON.parse(event.body);

    if (!userId) {
      console.error('Missing userId');
      throw new Error('Missing userId');
    }

    // build query
    // join profile
    const query = `
        UPDATE users
        SET first_name = $1, last_name = $2
        WHERE _id = $3
        RETURNING *
        ;
      `;
    const values = [firstName, lastName, userId];
    const result = await pool.query(query, values);
    const data = result.rows[0];

    const response = {
      success: true,
      status: 200,
      message: 'Query successful!',
      data,
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
