
import {Request, Response} from 'express';
import * as path from 'path';

interface PythonResult {
    readonly responseCode : number;
    readonly resultDetail : String;
};

export class ImageGenerator { 
    
    public routes(app): void {       
        app.route('/generateImage')
        .get((req: Request, res: Response) => {
            const queryText = req.query.text;
            const sentence = "'" + queryText+ "'";
            console.log('QUERY String: ' + queryText)

            const { spawn } = require('child_process');
            const pythonFilePath = path.join(__dirname + '/../../../Core/ImageGenerator.py');
            console.log(pythonFilePath);
            const pythonProcess = spawn('python3', [pythonFilePath, sentence]);
        
            let result = { responseCode: 0, resultDetail: 'String' }
            pythonProcess.stdout.on('data', (data) => {
                console.log('SUCCESS' + data.toString());
                result = { responseCode: 200, resultDetail: data.toString }
                res.status(result.responseCode).send(result.resultDetail);
            });
            
            pythonProcess.stderr.on('data', (data) => {
                console.log('FAILED: ' + data.toString());
                const errorString = 'Unexpected error occured while ' +
                                    'generating the image for sentence: ' + 
                                    queryText;
                result = { responseCode: 500, resultDetail: errorString }
                res.status(result.responseCode).send(result.resultDetail);
            });
        })               
    }
}