
import {Request, Response} from "express";

export class ImageGenerator { 
    
    public routes(app): void {       
        app.route('/generateImage')
        .get((req: Request, res: Response) => {            
            res.status(200).send("hello world!");
        })               
    }
}