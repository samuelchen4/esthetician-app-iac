const { Pool } = require('pg');
const { deleteServices, postServices, getServices } = require('./submethods');

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
  const client = await pool.connect();
  try {
    console.log('AddServicesById method start!');
    console.log('Received event:', JSON.stringify(event, null, 2));
    console.log('DB successfully connected!');

    const { userId } = event.pathParameters;
    const { services } = JSON.parse(event.body);

    if (!userId) {
      console.error('Missing clerkUserId');
      throw new Error('Missing clerkUserId');
    }

    // start transaction

    await client.query('BEGIN');

    // Delete services that ARENT IN the service array;
    await deleteServices(client, userId, services);
    // Post services IN the service array
    await postServices(client, userId, services);
    // Get all services to return
    const data = await getServices(client, userId);

    await client.query('COMMIT');

    const response = {
      success: true,
      status: 200,
      message: 'Query successful!',
      data: data,
    };
    return response;
  } catch (err) {
    await client.query('ROLLBACK');
    const response = {
      success: false,
      status: 500,
      message: err.message,
      data: err,
    };
    console.error('Error executing query', response);
    return response;
  } finally {
    client.release();
  }
};
