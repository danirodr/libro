//
//  ViewController.swift
//  Libro
//
//  Created by Daniel Rodríguez Pérez on 16/1/16.
//  Copyright © 2016 Daniel Rodríguez Pérez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var isbn: UITextField!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autores: UILabel!
    @IBOutlet weak var portada: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchISBN(sender: AnyObject) {
        self.resignFirstResponder()
        
        // Verificar la conexión
        let status = Reach().connectionStatus()
        
        switch status {
        case .Unknown, .Offline:
            let alertController = UIAlertController(title: "Error", message: "No se ha podido obtener los datos", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        case .Online(.WWAN):
            break
        case .Online(.WiFi):
            break
        }
        
        // Obtención de los datos del libro
        let url = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + self.isbn.text!)
        let datos : NSData? = NSData(contentsOfURL: url!)
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            
            let dico1 = json as! NSDictionary
            let keysdico1 = dico1.allKeys as NSArray
            
            if keysdico1.containsObject("ISBN:" + self.isbn.text!) {
                let dico2 = dico1["ISBN:" + self.isbn.text!] as! NSDictionary
                
                // Obten el titulo
                self.titulo.text = "Titulo: " + (dico2["title"] as! NSString as String)
                
                // Obten los authores
                var names = ""
                let authors = dico2["authors"] as! NSArray as Array
                
                for i in 1...authors.count {
                    if i == 1 {
                        names = authors[i - 1]["name"] as! NSString as String
                    } else if i == authors.count {
                        names = names + " y " + (authors[1]["name"] as! NSString as String)
                    } else {
                        names = names + " , " + (authors[1]["name"] as! NSString as String)
                    }
                }
                
                if authors.count > 1 {
                    self.autores.text = "Autores: " + names
                } else {
                    self.autores.text = "Autor: " + names
                }
                
                // Obtencion de la imagen
                guard let dico3 = dico2["cover"] else {
                    self.portada.image = UIImage()
                    return
                }
                
                let dico4 = dico3 as! NSDictionary
                if let imgURL = NSURL(string: dico4["large"] as! NSString as String) {
                    if let data = NSData(contentsOfURL: imgURL) {
                        self.portada.image = UIImage(data: data)
                    } else {
                        self.portada.image = UIImage()
                    }
                } else {
                    self.portada.image = UIImage()
                }
                
                
            } else {
                self.titulo.text = "Titulo"
                self.autores.text = "Autores"
                self.portada.image = UIImage()
            }
            
        } catch _ {
            self.titulo.text = "Titulo"
            self.autores.text = "Autores"
            self.portada.image = UIImage()
        }
    }

}
