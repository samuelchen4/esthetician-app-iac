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
    service,
    page = 1,
    limit = 20,
  } = event.queryStringParameters || event;
  const offset = (page - 1) * limit;

  if (!service) {
    throw new Error('No service provided!');
  }

  //  query
  const queryText = `
    SELECT
      u.*,
      (SELECT ARRAY_AGG(s.service_name ORDER BY CASE WHEN s.service_name = $2 THEN 0 ELSE 1 END)
      FROM services s
      WHERE s.user_id = u._id) AS services,
      (SELECT ARRAY_AGG(sc.day)
      FROM schedules sc
      WHERE sc.user_id = u._id) AS schedules
    FROM users u
    WHERE u.role = $1
    AND EXISTS (
      SELECT 1
      FROM services s
      WHERE s.user_id = u._id
      AND s.service_name = $2
    )
    LIMIT $3
    OFFSET $4
    ;
  `;

  const values = ['client', service, limit, offset];
  try {
    const result = await pool.query(queryText, values);

    const response = {
      success: true,
      status: 200,
      message: 'successful query',
      testing: result,
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
