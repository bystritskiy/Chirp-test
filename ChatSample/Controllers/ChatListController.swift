import ChirpConnect
import UIKit
import Foundation

let CHIRP_APP_KEY = "YOUR_CHIRP_APP_KEY"
let CHIRP_APP_SECRET = "YOUR_CHIRP_APP_SECRET"

class ChatListController: UIViewController {
    
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet var receivedLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    
    var connect: ChirpConnect?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendButton.layer.cornerRadius = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connect = ChirpConnect(appKey: CHIRP_APP_KEY, andSecret: CHIRP_APP_SECRET)
        
        if let connect = connect {
            connect.getLicenceString {
                (licence: String?, error: Error?) in
                if error == nil {
                    if let licence = licence {
                        connect.setLicenceString(licence)
                        connect.start()
                                                
                        connect.receivedBlock = {
                            (data: Data?) -> () in
                            if let data = data {
                                let payload = String(data: data, encoding: .utf8)!
                                self.receivedLabel.text = payload
                            } else {
                                print("Decode failed");
                            }
                        }
                        
                        connect.sendingBlock = { data in
                            self.receivedLabel.textColor = UIColor.green
                            self.receivedLabel.text = String(data: data, encoding: .utf8)!
                        }
                        
                        connect.sentBlock = { data in
                            self.receivedLabel.textColor = UIColor.black
                        }
                        
                        connect.receivingBlock = {
                            self.receivedLabel.text = "Получение..."
                        }
                        
                        connect.stateUpdatedBlock = { oldState, newState in
                            DispatchQueue.main.async(execute: {
                                switch newState {
                                case CHIRP_CONNECT_STATE_NOT_CREATED:
                                    self.stateLabel.textColor = .red
                                    self.stateLabel.text = "Не инициализирован"
                                case CHIRP_CONNECT_STATE_STOPPED:
                                    self.stateLabel.textColor = .red
                                    self.stateLabel.text = "Остановлен"
                                case CHIRP_CONNECT_STATE_PAUSED:
                                    self.stateLabel.textColor = .black
                                    self.stateLabel.text = "Приостановлен"
                                case CHIRP_CONNECT_STATE_RUNNING:
                                    self.sendButton.isEnabled = true
                                    self.stateLabel.textColor = .black
                                    self.stateLabel.text = "Запущен"
                                case CHIRP_CONNECT_STATE_SENDING:
                                    self.sendButton.isEnabled = false
                                    self.stateLabel.textColor = .green
                                    self.stateLabel.text = "Отправка..."
                                case CHIRP_CONNECT_STATE_RECEIVING:
                                    self.stateLabel.textColor = .green
                                    self.stateLabel.text = "Получение..."
                                default:
                                    print("Default state")
                                }
                            })
                        }
                        
                        connect.systemVolumeChangedBlock = { volume in
                            self.receivedLabel.text = String(format: "Изменение громкости: %.4f", volume)
                        }
                        
                        connect.authenticationStateUpdatedBlock = { error in
                            if let aDescription = error != nil ? error?.localizedDescription : "" {
                                print("Licence updated. \(aDescription)")
                            }
                        }
                        
                        
                    }
                }
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(false)
    }
    
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if (messageTextfield.text?.count)! > 0 {
            let text = (messageTextfield.text)!
            let data = Data(text.utf8)
            connect?.send(data)

            messageTextfield.text = ""
            view.endEditing(true)
        } else {
            let alert : UIAlertController = UIAlertController(title: "Ошибка", message: "Вы не ввели сообщение.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        if connect?.state == CHIRP_CONNECT_STATE_STOPPED {
            let error: Error? = connect?.start()
            if error != nil {
                if let anError = error {
                    print("Error starting engine: \(anError)")
                }
            } else {
                sendButton.isEnabled = true
                startStopButton.setTitle("Остановить транслятор", for: .normal)
            }
        } else {
            startStopButton.isEnabled = false
            connect?.stop(completion: {
                self.sendButton.isEnabled = false
                self.startStopButton.isEnabled = true
                self.startStopButton.setTitle("Включить транслятор", for: .normal)
            })
        }
    }
}
