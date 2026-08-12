import process from "node:process";
import { pathToFileURL } from "node:url";

const [apiPath, serverURL, password, syncId, dataDir] = process.argv.slice(2);

if (!apiPath || !serverURL || !password || !syncId || !dataDir) {
  throw new Error("Usage: sync_actual_export.mjs API_PATH SERVER_URL PASSWORD SYNC_ID DATA_DIR");
}

const { default: api } = await import(pathToFileURL(apiPath).href);

await api.init({ serverURL, password, dataDir });
try {
  await api.downloadBudget(syncId);
  await api.sync();
} finally {
  await api.shutdown();
}
