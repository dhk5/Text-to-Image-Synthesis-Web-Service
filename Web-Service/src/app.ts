import * as express from 'express';
import * as bodyParser from 'body-parser';

import {ImageGenerator} from './routes/imageGenerator';

class App {

    public app: express.Application;
    public imageGeneratorRoute = new ImageGenerator();

    constructor() {
        // Run the express instance and store in app
        this.app = express();
        this.config();
        this.imageGeneratorRoute.routes(this.app);
    }

    private config(): void {
        // Support application/json type post data
        this.app.use(bodyParser.json());
        // Support application/x-www-form-urlencoded post data
        this.app.use(bodyParser.urlencoded({
            extended: false
        }));
    }

}

export default new App().app;
