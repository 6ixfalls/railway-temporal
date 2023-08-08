import { NativeConnection, Worker } from '@temporalio/worker';
import * as activities from './activities';

async function run() {
  const worker = await Worker.create({
    workflowsPath: require.resolve('./workflows'),
    activities,
    taskQueue: 'activities-examples',
    connection: await NativeConnection.connect({
      address: "temporal.railway.internal:7233"
    })
  });

  await worker.run();
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
