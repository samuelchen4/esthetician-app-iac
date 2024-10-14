const { Pool } = require("pg");

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
console.log("Initalizing new DB connection");

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));
  console.log("Calling getAetheticians method");

  //   Props
  // Required:
  // city, province, lat, long, service, limit, page
  // optional
  // filter

  // Steps:
  //      1) Return error if any required props are missing
  //      2) Get aetheticians for the service and limit
  //      3) Map through aetheticians and calculate the distance using Haversine Formula
  //      4) Order the Array based on the filter
  //      5) Append distances to aetheticians array
  //      6) return array

  //   Destructure properties
  const {
    lat,
    long,
    city,
    province,
    service,
    filter,
    page = 1,
    limit = 10,
  } = event.queryStringParameters || event;
  const offset = (page - 1) * limit;

  //   Handle specific errors
  if (!lat || !long || !city || !province || !service) {
    throw new Error("Some required params missing!");
  }

  //  query
  const query = `
    SELECT
        u.*,
        (
            SELECT ARRAY_AGG(s.service_name ORDER BY CASE WHEN s.service_name = $2 THEN 0 ELSE 1 END)
            FROM services s
            WHERE s.user_id = u._id
        ) AS services
    FROM users u
    WHERE EXISTS (
        SELECT 1
        FROM services s
        WHERE s.user_id = u._id
        AND s.service_name = $1
    )
    LIMIT $2
    OFFSET $3;
  `;

  const values = [service, limit, offset];
  try {
    const result = await pool.query(query, values);
    // Procedure to calculate the distances from user

    const response = {
      success: true,
      status: 200,
      message: "successful query",
      testing: result,
      data: result.rows,
    };
    return response;
  } catch (err) {
    console.error("Error in getAetheticians lambda", err.message);
    const response = {
      success: false,
      status: 500,
      message: err.message,
      data: [],
    };
    return response;
  }
};
