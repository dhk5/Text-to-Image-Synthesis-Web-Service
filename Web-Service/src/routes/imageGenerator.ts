
import {Request, Response} from 'express';

import * as path from 'path';
import * as fs from 'fs';

export class ImageGenerator { 
    
    public routes(app): void {       
        app.route('/generateImage')
        .get((req: Request, res: Response) => {
            const queryText = req.query.text;
            const sentence = "'" + queryText+ "'";
            console.log('QUERY String: ' + queryText)

            const { spawn } = require('child_process');
            const pythonFilePath = path.join(__dirname + '/../../../Core/ImageGenerator.py');
            const pythonProcess = spawn('python3', [pythonFilePath, sentence]);
        
            let result = { responseCode: 0, resultDetail: 'String' }
            pythonProcess.stdout.on('data', (data) => {
                let returnedData =  data.toString().trim();
                console.log('SUCCESS: ' + returnedData);
                fs.stat(returnedData, function(err, data) {
                    if (err) {
                        console.log(err);
                        const errorString = 'Image could not be generated using the ' +
                                            'given sentence: ' + queryText;
                        res.status(500).send(errorString);
                    } else {
                        console.log('File exist!')
                        res.sendFile(returnedData);
                    }
                });
            });
            
            pythonProcess.stderr.on('data', (data) => {
                console.log('FAILED: ' + data.toString());
                const errorString = 'Unexpected error occured while ' +
                                    'generating the image for sentence: ' + 
                                    queryText;
                res.status(500).send(errorString);
            });
        })               
    }
}