async function deleteSchedules(client, userId, schedules) {
  const query = `
        DELETE FROM schedules
        WHERE user_id = $1 
        AND day != ALL($2::text[])
        RETURNING *;
      `;
  const values = [userId, schedules];
  const response = await client.query(query, values);
  return response.rows;
}

async function postSchedules(client, userId, schedules) {
  const query = `
        WITH schedule_list AS (
          SELECT UNNEST($2::text[]) AS schedule_day
        )
        INSERT INTO schedules (user_id, day)
        SELECT $1, schedule_day
        FROM schedule_list
        ON CONFLICT (user_id, day)
        DO NOTHING;
      `;
  const values = [userId, schedules];
  const response = await client.query(query, values);
  return response.rows;
}

async function getSchedules(client, userId) {
  const query = `
        SELECT * FROM schedules
        WHERE user_id = $1
        ORDER BY created_at DESC;
      `;
  const values = [userId];
  const response = await client.query(query, values);
  return response.rows;
}

module.exports = {
  deleteSchedules,
  postSchedules,
  getSchedules,
};
