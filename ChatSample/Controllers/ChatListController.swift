import ChirpConnect
import UIKit
import Foundation

let CHIRP_APP_KEY = "719e4DEf3cfF76EA9FB9A3ACB"
let CHIRP_APP_SECRET = "2C5dC1202fD8899F48EE24c12e4397fa54ad8C49a4F64d0De8"

class ChatListController: UIViewController {
    
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet var receivedLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    //    @IBOutlet weak var versionLabel: UILabel!
    
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
                                // ПОЛУЧЕНИЕ ДАННЫХ
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
    
//    func decodeMessage(_ data: Data) -> String? {
//        return String?
//    }
//
//    func encodeMessage(_ message: String?) -> Data? {
//        let string = String(utf8String: Int8(message?.utf8CString))
//        if (string?.lengthOfBytes(using: .utf8) ?? 0) > connect.maxPayloadLength() {
//            return nil
//        }
//        let stringData: Data? = string?.data(using: .utf8)
//        return (connect?.isValidPayload(stringData!))! ? stringData : nil
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(false)
    }
    
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if (messageTextfield.text?.count)! > 0 {
//            let payload: Data? = messageTextfield.text?.data(using: .ascii)
//            connect?.send(payload!)
//            let data: Data = connect!.randomPayload(withLength: UInt(connect!.maxPayloadLength))
            
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

//extension Data {
//    var hexString: String {
//        return map { String(format: "%02x", UInt8($0)) }.joined()
//    }
//}

