import { Request, Response } from 'express'

import * as path from 'path'
import * as fs from 'fs'

export class ImageGenerator {
    public routes(app): void {
        app.route('/generateImage').get((req: Request, res: Response) => {
            const queryText = req.query.text
            const sentence = "'" + queryText + "'"
            console.log('QUERY String: ' + queryText)

            const { spawn } = require('child_process')
            const pythonFilePath = path.join(
                __dirname + '/../../../Core/ImageGenerator.py'
            )
            const pythonProcess = spawn('python3', [pythonFilePath, sentence])

            pythonProcess.stdout.on('data', data => {
                let returnedData = data.toString().trim()
                if (returnedData == 'FAILED') {
                    const errorString =
                        'Image could not be generated using the ' +
                        'given sentence: ' +
                        queryText
                    console.log('FAILED')
                    res.status(500).send(errorString)
                } else {
                    fs.stat(returnedData, function(err, data) {
                        if (err) {
                            console.log(err)
                            const errorString =
                                'Image could not be found using the ' +
                                'given sentence: ' +
                                queryText
                            res.status(500).send(errorString)
                        } else {
                            console.log('File exist!')
                            res.sendFile(returnedData)
                        }
                    })
                }
            })
        })

        app.route('/getImage').get((req: Request, res: Response) => {
            const queryId = req.query.id
            const sentence = queryId
            console.log('QUERY String: ' + queryId)

            const { spawn } = require('child_process')
            const pythonFilePath = path.join(
                __dirname + '/../../../Core/ImageFetcher.py'
            )
            const pythonProcess = spawn('python3', [pythonFilePath, sentence])

            pythonProcess.stdout.on('data', data => {
                let returnedData = data.toString().trim()
                console.log('SUCCESS: ' + returnedData)
                fs.stat(returnedData, function(err, data) {
                    if (err) {
                        console.log(err)
                        const errorString =
                            'Image could not be found using the ' +
                            'given id: ' +
                            queryId
                        res.status(500).send(errorString)
                    } else {
                        console.log('File exist!')
                        res.sendFile(returnedData)
                    }
                })
            })
        })
    }
}
