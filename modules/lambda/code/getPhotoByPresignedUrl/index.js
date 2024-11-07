const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const region = process.env.REGION;
const bucketName = process.env.BUCKET_NAME;
const s3 = new S3Client({ region });

exports.handler = async (event) => {
  try {
    console.log('getPhotoByPresignedUrl method start!');
    console.log('Received event:', JSON.stringify(event, null, 2));

    // Parse keys from the request body (assuming JSON input)
    const { keys } = JSON.parse(event.body);
    console.log('keys: ', keys);

    if (!Array.isArray(keys) || keys.length === 0) {
      return {
        statusCode: 400,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET,OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
        body: JSON.stringify({
          success: false,
          message: 'Invalid input: keys should be a non-empty array.',
        }),
      };
    }

    // Generate presigned URLs for each key
    const presignedUrls = await Promise.all(
      keys.map(async (key) => {
        if (key.startsWith('/static/')) {
          return key;
        }
        try {
          const command = new GetObjectCommand({
            Bucket: bucketName,
            Key: key,
          });

          const presignedUrl = await getSignedUrl(s3, command, {
            expiresIn: 3600,
          });

          return presignedUrl;
        } catch (error) {
          console.error(
            `Error generating presigned URL for key ${key}:`,
            error
          );
          return { key, error: error.message };
        }
      })
    );
    console.log('presignedUrls :', presignedUrls);

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET,OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify({
        success: true,
        message: 'Presigned URLs successfully generated!',
        presignedUrls,
      }),
    };
  } catch (err) {
    console.error('Error executing query', err);
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET,OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify({
        success: false,
        message: 'Internal server error',
        error: err.message,
      }),
    };
  }
};
