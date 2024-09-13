async function deletePhotos(client, userId, photos) {
  const query = `
        DELETE FROM photos
        WHERE user_id = $1 
        AND image_url != ALL($2::text[])
        RETURNING *;
      `;
  const values = [userId, photos];
  const response = await client.query(query, values);
  return response.rows;
}

async function postPhotos(client, userId, photos) {
  const query = `
        WITH photo_list AS (
          SELECT UNNEST($2::text[]) AS photo_url
        )
        INSERT INTO photos (user_id, image_url)
        SELECT $1, photo_url
        FROM photo_list
        ON CONFLICT (user_id, image_url)
        DO NOTHING;
      `;
  const values = [userId, photos];
  const response = await client.query(query, values);
  return response.rows;
}

async function getPhotos(client, userId) {
  const query = `
        SELECT * FROM photos
        WHERE user_id = $1
        ORDER BY created_at DESC;
      `;
  const values = [userId];
  const response = await client.query(query, values);
  return response.rows;
}

module.exports = {
  deletePhotos,
  postPhotos,
  getPhotos,
};
