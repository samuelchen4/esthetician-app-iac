async function deleteServices(client, userId, services) {
  const query = `
      DELETE FROM services
      WHERE user_id = $1 
      AND service_name != ALL($2::text[])
      RETURNING *;
    `;
  const values = [userId, services];
  const response = await client.query(query, values);
  return response.rows;
}

async function postServices(client, userId, services) {
  const query = `
      WITH service_list AS (
        SELECT UNNEST($2::text[]) AS service_name
      )
      INSERT INTO services (user_id, service_name)
      SELECT $1, service_name
      FROM service_list
      ON CONFLICT (user_id, service_name)
      DO NOTHING;
    `;
  const values = [userId, services];
  const response = await client.query(query, values);
  return response.rows;
}

async function getServices(client, userId) {
  const query = `
      SELECT * FROM services
      WHERE user_id = $1
      ORDER BY created_at DESC;
    `;
  const values = [userId];
  const response = await client.query(query, values);
  return response.rows;
}

module.exports = {
  deleteServices,
  postServices,
  getServices,
};
