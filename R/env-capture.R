#' Private function for catpuring the source code of model
#'
#' @param funcs functions to capture, defaults to required promote model functions
#' @param capture.model.require flag to capture the model.require function
#' @importFrom utils capture.output
capture.src <- function(funcs, capture.model.require=TRUE){
    promote$model.require()
    if(missing(funcs)){
        funcs <- c("model.predict")
    }
    global.vars <- ls(.GlobalEnv)
    src <- ""
    if (capture.model.require==TRUE) {
      src <- paste(capture.output(promote$model.require),collapse="\n")
    }

    for(func in funcs){
        if(func %in% global.vars){
            func.src <- paste(capture.output(.GlobalEnv[[func]]), collapse="\n")
            func.src <- paste(func,"<-", func.src)
            src <- paste(src, func.src,sep="\n\n")
        }
    }
    src
}

#' Private function for recursively looking for variables
#'
#' @param block code block to spider
#' @param defined.vars variables which have already been defined within the
#'          scope of the block. e.g. function argument
promote.spider.block <- function(block,defined.vars=c()){
    # if block is a symbol, just return that symbol
    if(typeof(block) == "symbol") {
        return(c(block))
    }
    symbols <- c()
    n <- length(block)
    if(n == 0) {
        return(symbols)
    }
    for(i in 1:n){
        node <- block[[i]]
        # Really weird bug that comes from assigning the "empty" symbol to a
        # variable. No obvious way to test for this case other than a try/catch
        is.valid.symbol <- tryCatch({
            node
            TRUE
        }, error = function(e) {
            FALSE
        })
        if(!is.valid.symbol){ next }
        node.type <- typeof(node)
        # if node type is "symbol" then it might be a variable
        if(node.type == "symbol"){
            # if symbol not already defined then it might be a dependency
            if(!any(node == defined.vars)){
                symbols <- c(symbols,node)
            }
        # if node type is "language" then it is another block we'll want to spider
        } else if (node.type == "language"){
            # is the block an assignment statement? if so we'll want to add the
            # assignment result to the list of defined variables
            if ((node[[1]] == as.symbol("<-")) || (node[[1]] == as.symbol("="))){
                # Code will look like this:
                #     `assign.to` <- `assign.from`
                assign.from <- node[[3]]
                assign.from.type <- typeof(assign.from)
                if (assign.from.type == "symbol"){
                    # if symbol not already defined then it might be a dependency
                    if (!any(assign.from == defined.vars)){
                        symbols <- c(symbols, assign.from)
                    }
                } else if (assign.from.type == "language") {
                    symbols <- c(symbols, promote.spider.block(assign.from, defined.vars))
                }

                assign.to <- node[[2]]
                assign.to.type <- typeof(assign.to)
                if (assign.to.type == "symbol"){
                    # yay! the user has defined a variable
                    defined.vars <- c(assign.to,defined.vars)
                } else if (assign.to.type == "language"){
                    # Wait, what?!?! are you assigning to a block of code?
                    symbols <- c(symbols,promote.spider.block(assign.to, defined.vars))
                }
            } else {
                # if the block isn't an assignment, recursively crawl
                symbols <- c(symbols,promote.spider.block(node,defined.vars))
            }
        }
    }
    # return a list of symbols which are candidates for global dependency
    symbols
}

#' Private function for spidering function source code
#'
#' @param func.name name of function you want to spider
#' @importFrom utils getAnywhere
promote.spider.func <- function(func.name){
    # parse function to pull out main block and argument names
    func <- parse(text=getAnywhere(func.name))[[2]][[2]]
    # we will be comparing symbols not strings
    args <- lapply(names(func[[2]]),as.symbol)
    block <- func[[3]]
    # get all symbols used during function which are dependencies
    func.vars <- unique(promote.spider.block(block,defined.vars=args))
    # return dependency candidates which are defined in the global scope
    # (these are all variables we'll want to capture)
    intersect(func.vars,names(as.list(.GlobalEnv)))
}

#' Private function for determining model dependencies
#'
#' List all object names which are dependencies of and `model.predict`.
promote.ls <- function(){
    funcs <- c("model.predict") # function queue to spider
    global.vars <- ls(.GlobalEnv,all.names=T)
    if (!("model.predict" %in% global.vars)){
      err.msg <- "ERROR: You must define \"model.predict\" before deploying a model"
      stop(err.msg)
    }

    dependencies <- funcs
    while(length(funcs) > 0){
        # pop first function from queue
        func.name <- funcs[[1]]
        n.funcs <- length(funcs)
        if(n.funcs > 1){
            funcs <- funcs[2:length(funcs)]
        } else {
            funcs <- c()
        }
        # spider a function and get all variable dependencies
        func.vars <- promote.spider.func(func.name)
        n.vars <- length(func.vars)
        if(n.vars > 0){
            for(i in 1:n.vars){
                var <- func.vars[[i]]
                # is variable already a dependency?
                if(!(var %in% dependencies)){

                    dependencies <- c(var,dependencies)
                    # if this variable is a function we're going to
                    # want to spider it as well
                    if(typeof(.GlobalEnv[[var]]) == "closure"){
                        # add function to function queue
                        funcs <- c(var,funcs)
                    }
                }
            }
        }
    }
    if("model.require" %in% global.vars){
        stop("Warning: model.require is deprecated as of promoter 0.13.9 - please use promote.library to specify model dependencies")
    }
    dependencies
}
