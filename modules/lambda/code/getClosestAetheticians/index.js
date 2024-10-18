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
  console.log('Calling getClosestAethetician method');

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
    page = 1,
    limit = 10,
  } = event.queryStringParameters || event;
  const offset = (page - 1) * limit;

  // 1) Return error if any required props are missing
  if (!lat || !long || !city || !province) {
    throw new Error('Some required params missing!');
  }

  //  query
  const query = `
    SELECT
        u.*,
        (
            SELECT ARRAY_AGG(s.service_name ORDER BY s.service_name)
            FROM services s
            WHERE s.user_id = u._id
        ) AS services,
        (
            SELECT ARRAY_AGG(COALESCE(p.image_url_local, p.image_url))
            FROM photos p
            WHERE p.user_id = u._id
        ) AS photos
    FROM users u
    WHERE EXISTS (
        SELECT 1
        FROM services s
        WHERE s.user_id = u._id
    )
    ORDER BY u.rating DESC
    LIMIT $1
    OFFSET $2;
  `;

  const values = [limit, offset];
  try {
    const result = await pool.query(query, values);
    // Procedure to calculate the distances from user
    const aetheticians = result?.rows;

    //  3) Map through aetheticians and calculate the distance using Haversine Formula
    const aetheticiansWithDistances = aetheticians.map((user) => {
      const { latitude: userLat, longitude: userLong } = user;
      // convert to radian
      const userLatRad = userLat * (Math.PI / 180);
      const userLongRad = userLong * (Math.PI / 180);
      const latRad = lat * (Math.PI / 180);
      const longRad = long * (Math.PI / 180);
      console.log('userLatRad: ', userLatRad);
      console.log('userLongRad: ', userLongRad);
      console.log('latRad: ', latRad);
      console.log('longRad: ', longRad);
      const latDiff = userLatRad - latRad; // convert to Rad
      console.log('latDiff: ', latDiff);
      const longDiff = userLongRad - longRad; // convert to Rad
      console.log('longDiff: ', longDiff);

      const a =
        Math.sin(latDiff / 2) ** 2 +
        Math.cos(userLatRad) * Math.cos(latRad) * Math.sin(longDiff) ** 2;
      console.log('a: ', a);

      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      console.log('c', c);

      const earthRadius = 6371; // in Km

      const distance = earthRadius * c;
      console.log('distance: ', distance);

      return { ...user, distance };
    });

    const sortedArr = aetheticiansWithDistances.sort(
      (a, b) => a.distance - b.distance
    );

    const response = {
      success: true,
      status: 200,
      message: 'successful query',
      data: sortedArr,
    };
    return response;
  } catch (err) {
    console.error('Error in getClosestAethetician lambda', err.message);
    const response = {
      success: false,
      status: 500,
      message: err.message,
      data: [],
    };
    return response;
  }
};
