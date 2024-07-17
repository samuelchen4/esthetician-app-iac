const { Pool } = require('pg');
const bcryptjs = require('bcryptjs');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: {
    rejectUnauthorized: false,
  },
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});
console.log('Initializing new DB connection');

exports.handler = async (event) => {
  try {
    console.log('Received event:', JSON.stringify(event, null, 2));
    console.log('DB successfully connected!');

    const body = JSON.parse(event.body);

    const { username, password } = body;
    console.log(username, password);

    // const hashedPassword = await bcryptjs.hash(password, 10);
    // console.log(hashedPassword);
    // return hashedPassword;

    if (!username || !password) {
      console.error('Missing username or password');
      return {
        statusCode: 400,
        body: JSON.stringify({
          success: false,
          message: 'Missing username or password',
        }),
      };
    }

    const queryText = 'SELECT * FROM users WHERE username = $1';
    const values = [username];

    const result = await pool.query(queryText, values);

    if (result.rows.length === 0) {
      return {
        statusCode: 401,
        body: JSON.stringify({
          success: false,
          message: 'Invalid username or password',
        }),
      };
    }

    const user = result.rows[0];

    const isPasswordMatch = await bcryptjs.compare(password, user.password);

    if (!isPasswordMatch) {
      return {
        statusCode: 401,
        body: JSON.stringify({
          success: false,
          message: 'Invalid username or password',
        }),
      };
    }

    // Remove the password field before sending user data
    delete user.password;

    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        message: 'Login successful',
        data: user,
      }),
    };
  } catch (err) {
    console.error('Error executing query', err);
    return {
      statusCode: 500,
      body: JSON.stringify({ success: false, message: err.message }),
    };
  }
};
