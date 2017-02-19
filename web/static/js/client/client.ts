import { guid } from 'client/helpers';
import CatSocket from 'client/catsocket';

const DEBUG_SERVER: boolean = true;

const defaultOptions: CatsocketOptions = {
  production: true,
  user_id: null,
  host: null
};

const catsocket = {
  init(api_key: string, options: CatsocketOptions = defaultOptions) {
    var host = options["host"];

    // TODO - asssert that API key exists
    const user_id = options.user_id || guid();

    console.log("choosing env", process.env.NODE_ENV);
    if (process.env.NODE_ENV !== "production" && !options["production"]) {
      host = host || "ws://localhost:9000";
    } else {
      host = host || "ws://catsocket.com";
    }

    const cat = new CatSocket(api_key, user_id);
    cat.connect(host);

    return cat;
  }
};

export default catsocket;
