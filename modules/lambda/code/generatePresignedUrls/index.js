const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const region = process.env.REGION;
const bucketName = process.env.BUCKET_NAME;
const s3 = new S3Client({ region });

// body should be array of file names and type
exports.handler = async (event) => {
  try {
    console.log('generatePresignedUrls method start!');
    console.log('Received event:', JSON.stringify(event, null, 2));

    const { userId } = event.pathParameters;
    const { photos } = JSON.parse(event.body);

    if (!userId) {
      console.error('Missing userId');
      throw new Error('Missing userId');
    }

    const urls = await Promise.all(
      photos.map(async (photo) => {
        const { imageId, url: browserUrl, fileType } = photo;
        const key = `users/${userId}/photos/${imageId}`;
        const params = {
          Bucket: bucketName,
          Key: key,
          ContentType: fileType,
        };

        const command = new PutObjectCommand(params);

        const uploadURL = await getSignedUrl(s3, command, { expiresIn: 60 });

        return {
          imageId,
          browserUrl,
          uploadURL,
          contentType: fileType,
        };
      })
    );

    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        message: 'Presigned URLs successfully generated!',
        urls,
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
