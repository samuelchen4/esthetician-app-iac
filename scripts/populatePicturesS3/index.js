const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const fs = require('fs'); // For reading files from the local filesystem

// Create an S3 client instance
const s3Client = new S3Client({ region: 'us-west-2' });

const bucket = 'beauty-connect-user-portfolio-photos';
const picPaths = [
  'C:/Work/Esthetician App/pictures/frontend/profile/client-card-profile-picture.png',
];

// key: users/:userId/photos/

// takes the commandObj as params
const run = async (commandObj) => {
  try {
    const data = await s3Client.send(new PutObjectCommand(commandObj));
    console.log('Successfully uploaded object:', data);
  } catch (err) {
    console.error('Error uploading object:', err);
  }
};

const uploadPhotos = (userId, service) => {
  picPaths.forEach((picPath, i) => {
    const key = `users/${userId}/photos/${service}-${i + 1}.jpg`;
    const commandObj = {
      Bucket: bucket,
      Key: key,
      Body: fs.createReadStream(picPath),
    };
    run(commandObj);
  });
};

// uploadPhotos('4ceade7b-0858-48a7-9c9c-004f950ed032', 'Nails');

const uploadProfile = (userId) => {
  picPaths.forEach((picPath, i) => {
    const key = `users/${userId}/photos/profile/profile-picture.png`;
    const commandObj = {
      Bucket: bucket,
      Key: key,
      Body: fs.createReadStream(picPath),
    };
    run(commandObj);
  });
};

uploadProfile('d5947275-f2cf-4fc2-99fb-6ee64315f1fe');
