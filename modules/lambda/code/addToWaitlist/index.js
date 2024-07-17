const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

const client = new DynamoDBClient({ region: process.env.REGION }); // Change to your region
const tableName = process.env.TABLE_NAME;
console.log(tableName);
console.log(process.env.REGION);

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  const eventBody = JSON.parse(event.body);
  console.log(eventBody);
  const { name, email } = eventBody;

  const params = {
    TableName: tableName,
    Item: {
      _id: { S: email },
      name: { S: name },
      email: { S: email },
    },
  };
  console.log(params);

  try {
    const command = new PutItemCommand(params);
    await client.send(command);
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Item inserted successfully' }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Failed to insert item',
        error: error.message,
      }),
    };
  }
};
