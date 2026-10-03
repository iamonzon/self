{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import Text.Pandoc.Options (HTMLMathMethod (MathJax), writerHTMLMathMethod)

main :: IO ()
main = hakyll $ do
  match ("css/*" .||. "js/*" .||. "images/*") $ do
    route idRoute
    compile copyFileCompiler

  match "posts/*" $ do
    route $ setExtension "html"
    compile $
      mathPandoc
        >>= loadAndApplyTemplate "templates/post.html" postCtx
        >>= loadAndApplyTemplate "templates/default.html" postCtx
        >>= relativizeUrls

  -- top-level pages: portfolio.md, about.md, ...
  match "*.md" $ do
    route $ setExtension "html"
    compile $
      mathPandoc
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls

  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let ctx = listField "posts" postCtx (return posts) <> defaultContext
      getResourceBody
        >>= applyAsTemplate ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls

  match "templates/*" $ compile templateBodyCompiler

postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" <> defaultContext

-- $..$ and $$..$$ in markdown; MathJax renders them in the browser
mathPandoc :: Compiler (Item String)
mathPandoc =
  pandocCompilerWith
    defaultHakyllReaderOptions
    defaultHakyllWriterOptions {writerHTMLMathMethod = MathJax ""}
