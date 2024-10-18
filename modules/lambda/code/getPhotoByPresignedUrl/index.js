const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const region = process.env.REGION;
const bucketName = process.env.BUCKET_NAME;
const s3 = new S3Client({ region });

// body should be array of file names and type
exports.handler = async (event) => {
  try {
    console.log('getPhotoByPresignedUrl method start!');
    console.log('Received event:', JSON.stringify(event, null, 2));

    // const { userId, photoId } = event.pathParameters;
    const { key } = event.queryStringParameters;
    console.log('key: ', key);
    // const { key } = JSON.parse(event.body);

    // if (!userId || !key) {
    //   console.error('Missing userId or key');
    //   throw new Error('Missing userId or key');
    // }

    const command = new GetObjectCommand({
      Bucket: bucketName,
      Key: key,
    });

    const presignedUrl = await getSignedUrl(s3, command, {
      expiresIn: 3600,
    });

    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        message: 'Presigned URL successfully generated!',
        url: presignedUrl,
      }),
    };
  } catch (err) {
    const response = {
      success: false,
      status: 500,
      message: err.message,
      data: err,
    };
    console.error('Error executing query', response);
    return response;
  }
};
