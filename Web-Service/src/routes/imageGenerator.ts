
import {Request, Response} from "express";

export class ImageGenerator { 
    
    public routes(app): void {       
        app.route('/generateImage')
        .get((req: Request, res: Response) => {
            const queryText = req.query.text;
            const text = "'" + queryText+ "'";
            console.log("QUERY")
            console.log(text);

            const { spawn } = require('child_process');
            const pythonProcess = spawn('python3', ['/Users/rkang/Google Drive/School/MCSSE/Capstone/Text-to-Image-Synthesis-Web-Service/Core/ImageGenerator.py', text]);
        
            pythonProcess.stdout.on('data', (data) => {
                console.log("DATA SUCCESS");
                console.log(data.toString());
                res.status(200).send("hello world!");
            });
            
            pythonProcess.stderr.on('data', (data) => {
                console.log("DATA FAILED");
                console.log(data.toString());
                res.status(200).send("hello world!");
            });
        })               
    }
}