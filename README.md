Acqualta
========

Files per l'app iOS Acqualta. Il progetto è curato da www.acqualta.org e #opendatavenezia e realizzato gratuitamente da Apposta di Paolicelli Francesco Piero che cura anche questa repository. Per info Twitter:@piersoft oppure piersoft AT me.com

Testato per iOS6.1 fino al iOS7.0.4

Framework e librerie necessari:
CoreImage
MapKit
Accounts
AudioToolbox
Social
ImageIO
QuartzCore
CoreLocation
libz.dylib
MobileCoreServices
SystemConfiguration
CFNetwork
AddressBook
AddressBookUI
Foundation
CoreGraphics
UIKit

in Target ---> Build Settings --> Other Links Flag inserire --> "-licucore" senza "

Opzonale:
Per votare l'app su AppStore --> in Appirater.h sostituire 1111111 con l'APPLE ID di iTunes.
Infine, l'app prevede le notifiche push secondo lo schema di easypush.com. sostituire in AppDelegate.m la dicitura www.PIPPO.com con il sito in cui inserirete certificati e files per il corretto uso delle Push. Il file di registrazione è www.sito.xx/apns.php? ect
Ma non è necessario ovviamente.