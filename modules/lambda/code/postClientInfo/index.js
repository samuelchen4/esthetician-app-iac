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
  // Take a single connection from the pool for the transaction
  const client = await pool.connect();
  try {
    console.log('postClientInfo method start!');
    console.log('Received event:', JSON.stringify(event, null, 2));
    console.log('DB successfully connected!');

    const { userId } = event.pathParameters;
    const { clientInfoArray } = JSON.parse(event.body);
    // console.log('clientInfoArray: ', clientInfoArray);

    if (!userId) {
      console.error('Missing userId');
      throw new Error('Missing userId');
    }

    // start transactions
    await client.query('BEGIN');

    // insert basic info
    const results = await Promise.all([
      postUserInfo(client, userId, clientInfoArray[0]),
      postServices(client, userId, clientInfoArray[1]),
      postSchedule(client, userId, clientInfoArray[2]),
    ]);
    console.log('promises completed!');

    const [userInfoResult, servicesResult, scheduleResult] = results;
    console.log(userInfoResult, servicesResult, scheduleResult);

    await client.query('COMMIT');

    const responseData = {
      userInfo: userInfoResult,
      serivces: servicesResult,
      schedules: scheduleResult,
    };

    const response = {
      success: true,
      status: 200,
      message: 'Query successful!',
      data: responseData,
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
    // no matter what, this code will execute at the end
    client.release();
  }
};

async function postUserInfo(client, userId, userInfo) {
  try {
    const { firstName, lastName, email, isClient } = userInfo;
    const role = isClient ? 'client' : 'user';
    const query = `
            UPDATE users
            SET first_name = $1, last_name = $2, email = $3, role = $4
            WHERE _id = $5
            RETURNING *
            ; 
        `;
    const values = [firstName, lastName, email, role, userId];
    const result = await client.query(query, values);
    const data = result.rows[0];
    return data;
  } catch (err) {
    throw new Error(`Error in postServices method: ${err.message}`);
  }
}

async function postServices(client, userId, services) {
  try {
    const query = `
        WITH service_ids AS (
        SELECT _id
        FROM services
        WHERE service_name = ANY($2::text[])
        )
        INSERT INTO user_services (user_id, service_id)
        SELECT $1, service_ids._id
        FROM service_ids
        ON CONFLICT (user_id, service_id) DO NOTHING
        RETURNING *
        ;
  `;

    const values = [userId, services];
    const result = await client.query(query, values);
    const data = result.rows;
    return data;
  } catch (err) {
    throw new Error(`Error in postServices method: ${err.message}`);
  }
}

async function postSchedule(client, userId, days) {
  try {
    const query = `
        INSERT INTO user_schedules(user_id, day)
        SELECT $1, UNNEST($2::text[])
        RETURNING *
        ;
    `;
    const values = [userId, days];
    const result = await client.query(query, values);
    const data = result.rows;
    return data;
  } catch (err) {
    throw new Error(`Error in postSchedule method: ${err.message}`);
  }
}
