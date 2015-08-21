# PyJCR

PyJCR is a very simply yet powerful tool to build JCR6 files. As the "py" part in the name suggests the tool has been entirely written in Python.
Thanks to that this tool should be totally platform independent. Mac and most Linux distros already have Python present. On Windows you will need to separately install it.
The used Python version here is Python 2.7

### Novice usage
When you are not well versed in advanced usage you can just type "PyJCR c \<myjcr\> \<myfolder\>" in order to set up a simple JCR6 file.
With "PyJCR v \<myJCR\>" you can view a JCR6 and with "PyJCR x \<MyJCR>" you can extract stuff, if you ever need such a feature (I hardly use it myself).

### Advanced usage
When you are a more advanced user, you can use the true power of PyJCR and also take true advantage that the tool is entirely written in Python.
If you type "PyJCR s \<script\>" PyJCR will import your script file and make it part of its own and start working the way you want it. If your script ends on ".py" you can even skip the s command and just type "PyJCR \<script\>.py" and it will work all the same.
You script files should be (duh) written in pure Python code. 

A few commands you can use are:

- AddVar(var,value) - Will substitute all "var"s in file notes with the respective values. Best is to prefix all vars as the system is not able to distingish what is a var and what not otherwise.
- AddCmt(comment) - Will add a comment inside the JCR6 file. JCR viewers should always display those comments when viewing a JCR file. PyJCR and GJCR do
- Add(source,target,compressionalgorithm,author,notes) - Will add a file or directory to the JCR6 file with the chosen algoritm, author and notes. PyJCR supports by default "Store" (non-compression), "zlib" and "lzma". "lzma" is however not supported by the BlitzMax tools and modules for JCR6 (no satisfying module has ever been written for it. The ones that exist don't work at all), and if you want to use this tool to write patches for my games, you should stick to "zlib". If a file gets bigger in stead of smaller due to the chosen compression method the system will store it in non-compression automatically.
- Alias(Original,Target) - Will create an "alias" to a file. Basically this means that two references will exist to the same data. Please note that the extractor cannot see the difference and if you extract a JCR6 file whole this will mean the same data gets extracted twice. (as the extractor is not really a needed thing, protection against it is not on my high-priority list)
- AddImport(ImportFile[,requiredsignature]) - Will add an optional import file which JCR6 can import if it exists, and ignore if it doesn't. If you did set the signature the requested file must have the requeseted signature or it will be ignored
- AddRequire(ImportFile[,requiredsignature]) - Will add a required import file. Let's say if the required file does not exist the JCR6 loaders will refuse to load the JCR file and throw an error. If you are really a dependency-freak, here you got your tool to create them (I hate myself for supporting this).

Then there are also a few variables you can (or sometimes have to) set

- CJCR_Output - Must contain the name of the JCR6 file (default is Output.JCR)
- CJCR_FATStorage - Must contain the compression method used for storing the file table. By default "Store", I prefer to use "zlib"
- CJCR_Config - Is a directory in which certain settings can be done. A useful field you can define is "\_\_Sigature" to set the signature you can require for AddImport() and AddRequire() or just as and ID for your file (you can make your own engine check on this). You can set your own config with this if you want, fields prefixed with "\_\_" are reserved by me in case extra features are added to JCR6

And for the rest you can do whatever Python supports.
Please note the JCR6 file will be created AFTER your entire script has been run and not a moment sooner. This script will only configure pyJCR prior to running.

And that should cover all you need to know about this tool