%    Copyright (c) 2012-2016 Russell V. Lenth                                %

\name{ref.grid}
\alias{ref.grid}
\alias{.Last.ref.grid}


% handy for extra documentation...
\alias{ref.grid.object} 
\alias{summary.ref.grid.object}

\title{
Create a reference grid from a fitted model
}
\description{
Using a fitted model object, determine a reference grid for which least-squares means are defined. The resulting \code{ref.grid} object encapsulates all the information needed to calculate LS means and make inferences on them.
}
\usage{
ref.grid(object, at, cov.reduce = mean, mult.name, mult.levs, 
    options = get.lsm.option("ref.grid"), data, df, type, 
    transform = c("none", "response", "mu", "unlink", "log"), ...)
    
.Last.ref.grid
}

\arguments{
  \item{object}{An object produced by a supported model-fitting function, such as \code{lm}. Many models are supported. See \code{\link{models}}.}
  \item{at}{Optional named list of levels for the corresponding variables}
  \item{cov.reduce}{A function, logical value, or formula; or a named list of these. Each covariate \emph{not specified in} \code{at} is reduced according to these specifications. 
  
  If a single function, it is applied to each covariate. 
  
  If logical and \code{TRUE}, \code{mean} is used. If logical and \code{FALSE}, it is equivalent to specifying \samp{function(x) sort(unique(x))}, and these values are considered part of the reference grid; thus, it is a handy alternative to specifying these same values in \code{at}.
  
  If a formula (which must be two-sided), then a model is fitted to that formula using \code{\link{lm}}; then in the reference grid, its response variable is set to the results of \code{\link{predict}} for that model, with the reference grid as \code{newdata}. (This is done \emph{after} the reference grid is determined.) A formula is appropriate here when you think experimental conditions affect the covariate as well as the response.
  
  If \code{cov.reduce} is a named list, then the above criteria are used to determine what to do with covariates named in the list. (However, formula elements do not need to be named, as those names are determined from the formulas' left-hand sides.) Any unresolved covariates are reduced using \code{"mean"}.
  
Any \code{cov.reduce} specification for a covariate also named in \code{at} is ignored.
} % end of \item{cov.reduce}
  \item{mult.name}{Character, the name to give to the \dQuote{factor} whose levels delineate the elements of a multivariate response. If this is provided, it overrides the default name, e.g., \code{"rep.meas"} for an \code{\link[=lm]{mlm}} object or \code{"cut"} for a \code{\link[MASS]{polr}} object.}
  \item{mult.levs}{A named list of levels for the dimensions of a multivariate response. If there is more than one element, the combinations of levels are used, in \code{\link{expand.grid}} order. The (total) number of levels must match the number of dimensions. If \code{mult.name} is specified, this argument is ignored.}
  \item{options}{If non-\code{NULL}, a named \code{list} of arguments to pass to \code{\link{update}}, just after the object is constructed.}
  \item{data}{A \code{data.frame} to use to obtain information about the predictors (e.g. factor levels). If missing, then \code{\link{recover.data}} is used to attempt to reconstruct the data.}
  \item{df}{This is a courtesy shortcut, equivalent to specifying \code{options(df = df)}. See \code{\link{update}}.}
  \item{type}{If provided, this is saved as the \code{"predict.type"} setting. See \code{\link{update}}}
  \item{transform}{If other than \code{"none"}, the reference grid is reconstructed via \code{\link{regrid}} with the given \code{transform} argument. See Details.}
  \item{\dots}{Optional arguments passed to \code{\link{lsm.basis}}, such as \code{vcov.} (see Details below) or options for certain models (see \link{models}).}
} %--- end of \arguments

\details{The reference grid consists of combinations of independent variables over which predictions are made. Least-squares means are defined as these predictions, or marginal averages thereof.
The grid is determined by first reconstructing the data used in fitting the model (see \code{\link{recover.data}}), or by using the \code{data.frame} provided in \code{context}. The default reference grid is determined by the observed levels of any factors, the ordered unique values of character-valued predictors, and the results of \code{cov.reduce} for numeric predictors. These may be overridden using \code{at}.

Ability to support a particular class of \code{object} depends on the existence of \code{recover.data} and \code{lsm.basis} methods -- see \link{extending-lsmeans} for details. The call \code{methods("recover.data")} will help identify these.

In certain models, (e.g., results of \code{\link[lme4]{glmer.nb}}), 
it is not possible to identify the original dataset. In such cases, we can work around this by setting \code{data} equal to the dataset used in fitting the model, or a suitable subset.
Only the complete cases in \code{data} are used, so it may be necessary to exclude some unused variables.
Using \code{data} can also help save computing, especially when the dataset is large. In any case, \code{data} must represent all factor levels used in fitting the model. It \emph{cannot} be used as an alternative to \code{at}. (Note: If there is a pattern of \code{NAs} that caused one or more factor levels to be excluded when fitting the model, then \code{data} should also exclude those levels.)

By default, the variance-covariance matrix for the fixed effects is obtained from \code{object}, usually via its \code{\link{vcov}} method. However, the user may override this via a \code{vcov.} argument, specifying a matrix or a function. If a matrix, it must be square and of the same dimension and parameter order of the fixed efefcts. If a function, must return a suitable matrix when it is called with \code{object} as its only argument.

There is a subtle difference between specifying \samp{type = "response"} and \samp{transform = "response"}. While the summary statistics for the grid itself are the same, subsequent use in \code{\link{lsmeans}} will yield different results if there is a response transformation. With \samp{type = "response"}, LS means are computed by averaging together predictions on the \emph{linear-predictor} scale and then back-transforming to the response scale; while with \samp{transform = "response"}, the predictions are already on the response scale so that the LS means will be the arithmetic means of those response-scale predictions. To add further to the possibilities, \emph{geometric} means of the response-scale predictions are obtainable via \samp{transform = "log", type = "response"}.

The most recent result of \code{ref.grid}, whether called directly or indirectly via \code{\link{lsmeans}}, \code{\link{lstrends}}, or some other function that calls one of these, is saved in the user's environment as \code{.Last.ref.grid}. This facilitates checking what reference grid was used, or reusing the same reference grid for further calculations. This automatic saving is enabled by default, but may be disabled via \samp{lsm.options(save.ref.grid = FALSE)}, and re-enabled by specifying \code{TRUE}.
} % --- end of details

\value{An S4 object of class \code{"ref.grid"} (see \code{\link{ref.grid-class}}). These objects encapsulate everything needed to do calculations and inferences for least-squares means, and contain nothing that depends on the model-fitting procedure. As a side effect, the result is also saved as \code{.Last.ref.grid} (in the global environment, unless this variable is found in another position).
}


%%%\references{}

\author{
Russell V. Lenth
}
%\note{}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
See also \code{\link[lsmeans]{summary}} and other methods for the returned objects. Reference grids are fundamental to \code{\link{lsmeans}}. Click here for more on the \code{\link[=ref.grid-class]{ref.grid}} class. Supported models are detailed in \code{\link{models}}.
}

\examples{
require(lsmeans)

fiber.lm <- lm(strength ~ machine*diameter, data = fiber)
ref.grid(fiber.lm)
summary(ref.grid(fiber.lm))

ref.grid(fiber.lm, at = list(diameter = c(15, 25)))

\dontrun{
# We could substitute the sandwich estimator vcovHAC(fiber.lm)
# as follows:
require(sandwich)
summary(ref.grid(fiber.lm, vcov. = vcovHAC))
}

# If we thought that the machines affect the diameters
# (admittedly not plausible in this example), then we should use:
ref.grid(fiber.lm, cov.reduce = diameter~machine)

# Multivariate example
MOats.lm = lm(yield ~ Block + Variety, data = MOats)
ref.grid(MOats.lm, mult.name = "nitro")
# silly illustration of how to use 'mult.levs'
ref.grid(MOats.lm, mult.levs = list(T=LETTERS[1:2], U=letters[1:2]))
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ regression }
\keyword{ models }% __ONLY ONE__ keyword per line
