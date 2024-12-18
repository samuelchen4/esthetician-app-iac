const { Pool } = require('pg');
const { deletePhotos, postPhotos, getPhotos } = require('./submethods');

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
    console.log('AddPhotoById method start!');
    console.log('Received event:', JSON.stringify(event, null, 2));
    // return;
    console.log('DB successfully connected!');

    // const { userId } = event.pathParameters;

    // if (!userId) {
    //   console.log('Missing userId');
    //   throw new Error('Missing userId');
    // }

    // get the key
    const key = event.Records[0].s3.object.key;
    console.log('key: ', key);

    const parts = key.split('/');
    const userId = parts[1];

    const query = `
      INSERT INTO photos(user_id, image_url)
      VALUES($1, $2)
      ;
    `;

    const values = [userId, key];

    await pool.query(query, values);

    const response = {
      success: true,
      status: 200,
      message: 'Query successful!',
      // data: 'fill',
    };
    return response;
  } catch (err) {
    console.log(err);
    const response = {
      success: false,
      status: 500,
      message: err.message,
      data: err,
    };
    return response;
  }
};
