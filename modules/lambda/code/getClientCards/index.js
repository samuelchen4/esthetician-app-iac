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
    WITH filtered_users AS (
    SELECT 
        u._id,
        u.first_name,
        u.last_name,
        u.role,
        u.profile_picture,
        u.email,
        u.phone_number,
        u.username
    FROM 
        users u
    JOIN 
        user_services us ON u._id = us.user_id
    JOIN 
        services s ON us.service_id = s._id
    WHERE 
        u.role = $1 AND s.service_name = $2
    ),
    all_services AS (
        SELECT 
            u._id,
            u.first_name,
            u.last_name,
            u.role,
            u.profile_picture,
            u.email,
            u.phone_number,
            u.username,
            STRING_AGG(
                s.service_name, ', ' ORDER BY CASE WHEN s.service_name = $2 THEN 0 ELSE 1 END
            ) AS services
        FROM 
            filtered_users u
        JOIN 
            user_services us ON u._id = us.user_id
        JOIN 
            services s ON us.service_id = s._id
        GROUP BY 
            u._id, u.first_name, u.last_name, u.role, u.profile_picture, u.email, u.phone_number, u.username
        LIMIT $3
        OFFSET $4
    )
    SELECT 
        a.*
    FROM 
        all_services a
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
